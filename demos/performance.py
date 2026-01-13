"""
Performance Issue Demo

This file demonstrates an O(n²) algorithm that could be
optimized to O(n) using a set.

Forge will detect this and suggest optimization.
"""


def find_duplicates(items):
    """Find duplicate items - INEFFICIENT O(n²) algorithm."""
    duplicates = []
    # PERFORMANCE ISSUE: Nested loops = O(n²)
    for i in range(len(items)):
        for j in range(len(items)):
            if i != j and items[i] == items[j] and items[i] not in duplicates:
                duplicates.append(items[i])
    return duplicates


if __name__ == "__main__":
    # This is slow for large lists
    test_list = list(range(500)) + list(range(250))
    print(f"Found {len(find_duplicates(test_list))} duplicates")
