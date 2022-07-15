<img src="https://user-images.githubusercontent.com/40375449/178133939-f280d6d1-8d37-4115-9470-516c1df1ae3b.png" alt="gameLogo" width="100"/>

**One Step Ahead**<br>

By Ethan Marshall :)

# Quick Start
The game is designed for iPhone, iPad, and Apple Silicon Macs! To start up the app, you can either download and run the Xcode project or get the game right from the [App Store](https://apps.apple.com/us/app/one-step-ahead/id1620737001)!

> **Warning**<br>
> Standard gameplay is not compatible with the Xcode Simulator, since the app relies on the Create ML framework. Please be sure to build and run the app on a physical device.

# Running with Simulator
If you would like to run the game with the Xcode Simulator or use SwiftUI previews, use the following steps to disable AI judging:

1. Find all uses of the `getAIscore()` function and replace them with a static `50.0`, or whichever substitute score you would like to assign the AI during games.
2. Comment out or delete all code in the `MLServices.swift` file.

# Support & Feedback

To view options for getting game support and leaving feedback, visit the [Support Center wiki page](https://github.com/BaBingoBango/One-Step-Ahead/wiki/Support-Center).

# Privacy Policy

To view the privacy policy for the game, visit the [Privacy Policy wiki page](https://github.com/BaBingoBango/One-Step-Ahead/wiki/Privacy-Policy).

# Licensing and Credit
To view the third-party content used in the app, navigate to Settings > Licensing and Credit from the game's main menu. The information is also summarized below:

## Images

- [Blue Background Image](https://unsplash.com/photos/_0eMNseqmYk) via the [Unsplash License](https://unsplash.com/license)
- [Space Background Image](https://unsplash.com/photos/qVotvbsuM_c) via the [Unsplash License](https://unsplash.com/license)

## Music

- ["Lounge Drum and Bass"](https://pixabay.com/music/drum-n-bass-lounge-drum-and-bass-108785/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Space Chillout"](https://pixabay.com/music/upbeat-space-chillout-14194/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Acceleron"](https://pixabay.com/music/synthwave-acceleron-109122/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Autobahn"](https://pixabay.com/music/house-autobahn-99109/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Dancing Racoons"](https://pixabay.com/music/soft-house-dancing-racoons-20793/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Dragonfly"](https://pixabay.com/music/deep-house-dragonfly-15128/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Protection of Me"](https://pixabay.com/music/deep-house-protection-of-me-by-nazartino-112859/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Scandinavianz Palmtrees"](https://pixabay.com/music/upbeat-scandinavianz-palmtrees-7326/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)
- ["Synthwave 80s"](https://pixabay.com/music/synthwave-synthwave-80s-110045/) via the [Simplified Pixabay License](https://pixabay.com/service/license/)

## Sound Effects

- [Dun Dun Dun Sound Effect](https://freesound.org/people/copyc4t/sounds/146434/) via the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/)
- [Game Victory Jingle](http://freemusicarchive.org/) via the [Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License](https://creativecommons.org/licenses/by-nc-nd/3.0/)
- [Game Defeat Jingle](http://freemusicarchive.org/) via the [Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License](https://creativecommons.org/licenses/by-nc-nd/3.0/)

## Assets

- [Google Quick, Draw! Dataset](https://quickdraw.withgoogle.com/data) via the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/)

## Software

- [Zephyr](https://github.com/ArtSabintsev/Zephyr) via the [MIT License](https://github.com/ArtSabintsev/Zephyr/blob/master/LICENSE)
