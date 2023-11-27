#include <bitset>
#include <cstdlib>
#include <iostream>

constexpr int max_n = 700;
constexpr int iterations = 1000;

std::bitset<max_n> matrix[max_n];

void gen_random_matrix(const int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            matrix[i][j] = rand() % 2;
        }
    }
}

bool is_max_rank(const int n) {
    for (int i = 0; i < n; ++i) {
        int j = i;
        while (j < n && !matrix[j][i]) ++j;
        if (j == n) return false;
        std::swap(matrix[i], matrix[j]);
        for (int j = i + 1; j < n; ++j) {
            if (matrix[j][i]) matrix[j] ^= matrix[i];
        }
    }
    return true;
}

double probability_max_rank(const int n) {
    int max_rank = 0;
    for (int i = 0; i < iterations; ++i) {
        gen_random_matrix(n);
        max_rank += is_max_rank(n);
    }
    return static_cast<double>(max_rank) / iterations;
}

int main() {
    for (int n = 0; n <= max_n; ++n) {
        std::cout << n << " " << probability_max_rank(n) << std::endl;
    }
}
