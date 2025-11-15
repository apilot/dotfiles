#!/usr/bin/env python3
"""
Test file for Aider integration
This is a simple Python file to test the aider.nvim integration.
"""

def hello_world(name: str) -> str:
    """
    Simple function to greet someone.

    Args:
        name: The name of the person to greet

    Returns:
        A greeting message
    """
    return f"Hello, {name}!"


def main():
    """Main function"""
    print(hello_world("World"))


if __name__ == "__main__":
    main()