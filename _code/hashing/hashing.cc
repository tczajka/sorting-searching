#include <cstdlib>
#include <iostream>
#include <unordered_set>

std::unordered_set<long> generate_data(long A, long B) {
  std::unordered_set<long> data;
  for (long i=1; i<=A; ++i) data.insert(i * B);
  std::cerr << "buckets: " << data.bucket_count() << "\n";
  return data;
}

long sum(const std::unordered_set<long> &data) {
  long res = 0;
  for (long x : data) res += x;
  return res;
}

int main(int argc, char **argv) {
  long A = std::atoi(argv[1]);
  long B = std::atoi(argv[2]);
  auto data = generate_data(A, B);
  std::cout << sum(data) << "\n";
}
