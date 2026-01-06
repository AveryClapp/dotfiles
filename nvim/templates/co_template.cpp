#include <bits/stdc++.h>

using namespace std;

/**
 * MACROS & TYPEDEFS
 */
typedef long long ll;
typedef vector<int> vi;
typedef pair<int, int> pii;

#define fastio()                                                               \
  ios_base::sync_with_stdio(false);                                            \
  cin.tie(NULL);                                                               \
  cout.tie(NULL)
#define pb push_back
#define mp make_pair
#define all(x) (x).begin(), (x).end()
#define sz(x) ((int)(x).size())

/**
 * DEBUGGING TOOLS (Only active locally)
 */
#ifndef ONLINE_JUDGE
#define debug(x)                                                               \
  cerr << #x << " ";                                                           \
  _print(x);                                                                   \
  cerr << endl;
#else
#define debug(x)
#endif

void _print(ll t) { cerr << t; }
void _print(int t) { cerr << t; }
void _print(string t) { cerr << t; }
void _print(char t) { cerr << t; }

template <class T, class V> void _print(pair<T, V> p);
template <class T> void _print(vector<T> v);
template <class T, class V> void _print(pair<T, V> p) {
  cerr << "{";
  _print(p.first);
  cerr << ",";
  _print(p.second);
  cerr << "}";
}
template <class T> void _print(vector<T> v) {
  cerr << "[ ";
  for (T i : v) {
    _print(i);
    cerr << " ";
  }
  cerr << "]";
}

/**
 * PROBLEM SOLVING LOGIC
 */
void solve() {
  // Your code here
}

int main() {
  fastio();

  int t = 1;
  cin >> t; // Comment this out if the problem has only one test case
  while (t--) {
    solve();
  }

  return 0;
}
