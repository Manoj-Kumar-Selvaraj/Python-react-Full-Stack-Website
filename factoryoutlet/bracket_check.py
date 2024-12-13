def check_balanced_symbols(file_path):
    with open(file_path, 'r') as file:
        code = file.read()

    stack = []
    line_numbers = []

    # Mapping of closing to opening symbols
    matching_symbols = {')': '(', '}': '{', ']': '['}
    opening_symbols = matching_symbols.values()

    lines = code.splitlines()

    for line_num, line in enumerate(lines, 1):
        for char in line:
            if char in opening_symbols:
                # If it's an opening symbol, push it to the stack
                stack.append((char, line_num))
            elif char in matching_symbols:
                # If it's a closing symbol, check if it matches the top of the stack
                if stack and stack[-1][0] == matching_symbols[char]:
                    stack.pop()  # If it matches, pop the stack
                else:
                    # If it doesn't match, it's an unbalanced closing symbol
                    print(f"Unmatched closing symbol '{char}' at line {line_num}")
                    line_numbers.append(line_num)

    # If there are still items in the stack, it means there are unmatched opening symbols
    while stack:
        unmatched_symbol, line_num = stack.pop()
        print(f"Unmatched opening symbol '{unmatched_symbol}' at line {line_num}")
        line_numbers.append(line_num)

    if not line_numbers:
        print("All symbols are balanced.")
    return line_numbers


# Provide the path to your React code file
file_path = '/factoryoutlet/factoryoutlet/react.js'
check_balanced_symbols(file_path)
