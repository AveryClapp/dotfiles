;;; competitive.el -*- lexical-binding: t; -*-
;; Minimal Competitive Companion workflow for Emacs -- a from-scratch port of the
;; nvim comp-prog flow (receive / run / add / edit / submit).
;;
;; HOW IT WORKS
;;   `cp-receive' opens a one-shot TCP listener on `cp-port'. Click the green
;;   "Competitive Companion" browser button on a problem page; the extension POSTs
;;   the problem JSON, and we write each sample case to ./tests/N.in and ./tests/N.out.
;;   `cp-run' compiles the current file and diffs its output against every sample.
;;
;; PARITY NOTES vs your nvim setup
;;   - receive/run/add/edit work.
;;   - submit is a STUB: it opens the problem URL in a browser. Programmatic
;;     submission (Codeforces login/automation) is not ported -- it needs auth and
;;     is out of scope for a config. See README.

(require 'cl-lib)
(require 'json)

(defvar cp-port 27121
  "Port Competitive Companion POSTs to. Set the extension's custom port to match.")
(defvar cp-test-dir "tests" "Directory (relative to source file) for sample cases.")
(defvar cp-cpp-std "c++20" "C++ standard used when compiling .cpp solutions.")
(defvar cp--server nil)
(defvar cp--last-url nil "URL of the most recently received problem (for submit).")

;;; -- receive ----------------------------------------------------------------

(defun cp--write-tests (data)
  "Write sample cases from parsed Competitive Companion DATA to `cp-test-dir'."
  (let* ((tests (alist-get 'tests data))
         (dir   (expand-file-name cp-test-dir default-directory)))
    (setq cp--last-url (alist-get 'url data))
    (make-directory dir t)
    (cl-loop for test across tests
             for i from 1 do
             (with-temp-file (expand-file-name (format "%d.in" i) dir)
               (insert (or (alist-get 'input test) "")))
             (with-temp-file (expand-file-name (format "%d.out" i) dir)
               (insert (or (alist-get 'output test) ""))))
    (message "CP: wrote %d sample(s) to %s" (length tests) dir)))

(defun cp--filter (proc string)
  "Accumulate the HTTP request on PROC; parse JSON body once complete."
  (process-put proc 'buf (concat (process-get proc 'buf) string))
  (let* ((req (process-get proc 'buf))
         (sep (string-search "\r\n\r\n" req)))
    (when sep
      (let ((body (substring req (+ sep 4))))
        (condition-case err
            (let ((json (json-parse-string body :object-type 'alist :array-type 'array)))
              (cp--write-tests json)
              (ignore-errors
                (process-send-string proc "HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")))
          (error (message "CP: parse failed: %s" err)))
        (ignore-errors (delete-process proc))))))

;;;###autoload
(defun cp-receive ()
  "Listen once for a Competitive Companion problem and save its samples."
  (interactive)
  (when (process-live-p cp--server) (delete-process cp--server))
  (setq cp--server
        (make-network-process
         :name "cp-listener" :server t :host 'local :service cp-port
         :family 'ipv4 :coding 'binary :filter #'cp--filter))
  (message "CP: listening on :%d -- click Competitive Companion now" cp-port))

;;; -- run --------------------------------------------------------------------

(defun cp--compile (file bin)
  "Compile FILE to BIN by extension. Return t on success, nil otherwise."
  (pcase (file-name-extension file)
    ("cpp" (zerop (call-process-shell-command
                   (format "g++ -std=%s -O2 -o %s %s"
                           cp-cpp-std (shell-quote-argument bin)
                           (shell-quote-argument file)))))
    ("rs"  (zerop (call-process-shell-command
                   (format "rustc -O -o %s %s"
                           (shell-quote-argument bin) (shell-quote-argument file)))))
    ("py"  t)                            ; interpreted, nothing to build
    (_ (user-error "CP: unsupported extension"))))

(defun cp--run-cmd (file bin)
  (pcase (file-name-extension file)
    ("py" (format "python3 %s" (shell-quote-argument file)))
    (_    (shell-quote-argument bin))))

;;;###autoload
(defun cp-run ()
  "Compile the current file and diff its output against every sample case."
  (interactive)
  (let* ((file (buffer-file-name))
         (dir  (file-name-directory file))
         (bin  (expand-file-name "cp.out" dir))
         (tests (sort (file-expand-wildcards
                       (expand-file-name (concat cp-test-dir "/*.in") dir))
                      #'string<))
         (out (get-buffer-create "*cp-run*")))
    (unless file (user-error "CP: buffer has no file"))
    (unless tests (user-error "CP: no tests in ./%s (run cp-receive)" cp-test-dir))
    (with-current-buffer out (erase-buffer))
    (unless (cp--compile file bin)
      (user-error "CP: compilation failed"))
    (let ((cmd (cp--run-cmd file bin)) (pass 0) (total 0))
      (dolist (in tests)
        (cl-incf total)
        (let* ((expected (with-temp-buffer (insert-file-contents (concat (file-name-sans-extension in) ".out"))
                                            (string-trim (buffer-string))))
               (actual (string-trim
                        (with-output-to-string
                          (with-temp-buffer
                            (insert-file-contents in)
                            (call-process-region (point-min) (point-max)
                                                 shell-file-name nil standard-output nil
                                                 shell-command-switch cmd)))))
               (ok (string= expected actual)))
          (when ok (cl-incf pass))
          (with-current-buffer out
            (insert (format "Test %s: %s\n" (file-name-base in)
                            (if ok "PASS" "FAIL")))
            (unless ok
              (insert (format "  expected: %S\n  got:      %S\n" expected actual))))))
      (with-current-buffer out
        (goto-char (point-min))
        (insert (format "=== %d/%d passed ===\n\n" pass total)))
      (display-buffer out))))

;;; -- add / edit / submit ----------------------------------------------------

;;;###autoload
(defun cp-add-test ()
  "Create the next empty N.in / N.out pair and open the input."
  (interactive)
  (let* ((dir (expand-file-name cp-test-dir (file-name-directory (buffer-file-name))))
         (n (1+ (length (file-expand-wildcards (expand-file-name "*.in" dir))))))
    (make-directory dir t)
    (write-region "" nil (expand-file-name (format "%d.out" n) dir))
    (find-file (expand-file-name (format "%d.in" n) dir))))

;;;###autoload
(defun cp-edit-tests ()
  "Open the tests directory in dired to edit sample cases."
  (interactive)
  (dired (expand-file-name cp-test-dir (file-name-directory (buffer-file-name)))))

;;;###autoload
(defun cp-submit ()
  "STUB: open the problem URL. Programmatic submission is not ported (see README)."
  (interactive)
  (if cp--last-url
      (browse-url cp--last-url)
    (message "CP: no problem URL yet (run cp-receive first)")))

(provide 'competitive)
;;; competitive.el ends here
