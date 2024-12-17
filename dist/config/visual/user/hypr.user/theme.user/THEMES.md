# Themes

These themes are to be used by all apps in the `hypr` ecosystem, thus helping reach a more uniform desktop look, as well as centralized theme management.

## Structure

All themes must follow a definite structure.

This structure is formed from *color categories*, color categories are where each theme defines the colors to use for a specific context, each color category has a definite amount of individual colors.
However, color categories are not meant to be too concise about the context where they are used, such thing is left to the user.

As of now, only the following color categories exist:

- `foreground-n`, where `n` ranges from `0` to `8`
- `background-n`, where `n` ranges from `0` to `8`
- `accent-n`, where `n` ranges from `0` to `8`

If there are not enough colors in an arbitrary theme to fill in a color category, the last assigned color saturates until fullfillment.

In the case of `hyprlang`, (the language used for themes and overall configuration of apps of the hypr ecosystem), each color will have a `*-code` variant, where it is simply the RGB components of each color.
Such variant is useful when defining RGBA colors, as it allows to define the alpha channel, independently from the color itself. An example of this is `rgba($*-code<transparency>)`, where the wildcard expresses an arbitrary base color.

## Recommendations

If you are converting a foreign theme (such as `Catppuccin Mocha`, or something else), you can separate 
