#include <iostream>
#include "math_operations.h"

int g_tests = 0;
int g_failures = 0;

#define EXPECT_EQ(actual, expected) \
    do { \
        ++g_tests; \
        auto _a = (actual); \
        auto _e = (expected); \
        if (_a != _e) { \
            ++g_failures; \
            std::cerr << "FAIL: " << __FILE__ << ":" << __LINE__ \
                      << " - EXPECT_EQ(" #actual ", " #expected ") -> got " << _a \
                      << " expected " << _e << std::endl; \
        } \
    } while (0)

int main() {
    std::cout << "Running unit tests for math_operations::add()\n";

    // Basic cases
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(-1, -2), -3);
    EXPECT_EQ(add(0, 0), 0);

    // Mixed signs
    EXPECT_EQ(add(10, -4), 6);
    EXPECT_EQ(add(-7, 3), -4);

    // Commutativity
    EXPECT_EQ(add(42, 17), add(17, 42));
    EXPECT_EQ(add(-5, 5), add(5, -5));

    // Larger but safe values
    EXPECT_EQ(add(100000, 200000), 300000);
    EXPECT_EQ(add(-100000, -200000), -300000);

    // Summary
    if (g_failures == 0) {
        std::cout << "All " << g_tests << " tests passed.\n";
        return 0;
    } else {
        std::cerr << g_failures << " test(s) failed out of " << g_tests << ".\n";
        return 1;
    }
}
