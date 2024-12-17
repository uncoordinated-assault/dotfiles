# Structure

All themes must follow a definite structure.

This structure is formed from *color categories*, color categories are where each theme defines the colors to use for a specific context, each color category has a definite amount of individual colors.
However, color categories are not meant to be too concise about the context where they are used, such thing is left to the user.

As of now, only the following color categories exist:

- `foreground-n`, where `n` ranges from `0` to `8`
- `background-n`, where `n` ranges from `0` to `8`
- `accent-n`, where `n` ranges from `0` to `8`

If there are not enough colors in an arbitrary theme to fill in a color category, the last assigned color saturates until fullfillment.

## Recommendations

If you are converting a foreign theme (such as `Catppuccin Mocha`, or something else), you can separate the theme-specific color definitions to a different file, then import such file to your actual theme definition.
