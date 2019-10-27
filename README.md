# Fouris
 Fouris is a dropping block game popularized by Tetris. However, Fouris rotates the board after each piece is frozen, making stategy more important than with one-dimensional block dropping games - what may be a good place for a piece in one orientation may cause trouble when the board rotates.

Fouris was originally written to be cross-compilable for both macOS and iOS using lots of conditional compilation and multiple storyboards. While successful, this approach used up a lot of time and was ultimately abandoned in favor of an iOS/iPadOS-only version. Perhaps new Xcode/macOS tools will let me run this on my Mac again in the future...
## Author and Copyright
Fouris was written by Stuart Rankin.

Fouris is Copyright © 2019 by Stuart Rankin. All right reserved.

Tetris is a registered trademark of Tetris.
## Program Documentation
Please refer to [Fouris Documentation Index](https://github.com/sjrankin/Fouris/blob/master/docs/index.html) for programmatic documentation.
## Versioning
Versioning for Fouris is maintained in the Versioning.swift file and is updated with a program prior to each build to increment the build number and update the date and time. The nice thing about this is I don't have to remember to update build numbers or insert the current time. The bad thing is every time I build the identical code (perhaps for various devices), I get different build numbers...

Also, this versioning does not utilize Xcode's built-in versioning so I'll have to update that manually.

Most recent build: **Version a.b Build xyz, Date: When**

> This documentation and the Jazzy-created documentation do not necessarily reflect the build shown above.
## Implementation and Requirements
Fouris is written in Swift (5.2 as of time of writing) and intended for iOS/iPadOS 13 or higher. *Fouris explicitly requires iOS/iPadOS 13 or higher or it will not load/run.* Eventually Fouris may take advantage of a Metal program that uses a flood fill algolrithm for gap counting. This code, written in C, exists but is not debugged or used at this time.

Fouris is implemented mostly with SceneKit. SceneKit is used to draw the game view and most controls on the screen. The main menu (the rotating cube) and its child windows all use UIKit. Currently, Fouris uses a text overlay for some UI elements (see also [Planned](#Planned)).
### Toolchain
Fouris was compiled with Xcode 11.2 Beta 2 (11B44). Fouris requires a minimum Xcode version of 11.
### Simulator
With Xcode 11.2 and macOS 10.15, running Fouris in a simulator is faster than running on native hardware. Given the changes Apple made to how the simulator works, Fouris has access to desktop-class (assuming you are running on a desktop) processors and GPUs. It makes debugging graphics a *lot* easier...
### Testing
Fouris runs with good graphics performance on iPhone 6Ss and above, as well as iPad Mini 4s and newer. The frame rate is a consistent 60 frames per second (+/- 1 FPS).

Fouris has run on a simulator for over 99 hours (and would have continued for a longer period except my iMac had a forced restart).

No battery testing has been done although I suspect given the intensive 3D graphics involved, battery life would be an issue.

Fouris has been tested on the following hardware:
- iPhone 6S+
- iPhone 8
- iPad Mini 4
- iPad Pro 9.7
### Issues
- Gravity slow-down. For some reason, gravity gets weaker the longer the game plays. This doesn't seem to happen on the simulator until about 180,000 seconds of game time have elapsed, but on an actual device, it happens almost immediately (especially in non-classic game modes). This also seems to happen over the duration of the instantiation of the game.
- Better AI - the AI is essentially a brute-force method of looking for a place to drop pieces that do the least amount of damage. The AI can't see around corners and is very slow in some circumstances.
  - The AI for rotating games with bottomless columns needs to be smarter and not move things to locations just because there's a way to plug a bottomless location at the expense of leaving a piece above the top of the bucket.
- Scoring is mixed up. Scores go up and down seemingly randomly.
- The documentation generator Jazzy seems bound and determined to not work.
- iOS/iPadOS 13 broke multipeer networking (I have a bug in with Apple). Until it's back, I can't log remotely or use remote systems to control Fouris.
- Drawing lines in 3D with SceneKit is unnecessarily heavy - there are ways to draw lines but they are visually very unattractive. I had to resort to drawing very thin and long boxes to simulate lines.
- After the first rotation, the initial piece disappears during rotation but reappears correctly later. This is only for the first rotation of the game.
- Extensions are scattered throughout the source tree and need to be consolidated.
### What to do Differently
From what I learned, I would do the following differently:
1. Use Unity instead of SceneKit. SceneKit is "free" and built-in to iOS, but its documentation is thin and not always easy to decipher. Getting help from Apple is also difficult (except for paid incidents). Unity has issues as well but there seem to be more people using it so more community answers and help.
2. Reduce the complexity of the game - there are too many layers just to get a piece to move.
3. Make explicit use of threading for better control of when things happen. Threading issues and timer issues are difficult to debug.
4. Maybe not always use the latest beta of Xcode. Sometimes I spent half a day filing feedback and writing bug reproduction programs...
5. SF Symbols is nice but inadquate for full program use at this time (eg, in strings, not as graphic images). I had to embed Noto Emoji to get non-Apple reserved images of cameras and videos.
6. Too many board types. Need to remove those that are similar or just don't work.
7. Too many color utilites and manipulation classes/functions. This is a result of importing older code as well as new code. Should probably be refactored, combined, and reduced...
### Planned
1. Add remote feature such that one iDevice can act as a remote control for another iDevice.
2. Better adapt the UI for iPhones - Fouris was developed on an iPad and you can tell...
3. Multi-user version.
4. tvOS version.
5. AI versus human.
6. Hexagon game mode.
7. Better icons and start-up image.
8. Move all UI elements into the game view and use SceneKit for all text rather than using a CALayer on top of a SCNView. (However, SCNText doesn't respect NSAttributedStrings very well so most visual attributes are lost.)
9. Get the activity log working such that a huge number of log files aren't generated as they are now (perhaps this is more of an "issue"...).
10. ~~Add rotations to more than just the z-axis.~~ Done (mostly).
11. Finish Metal program for gap counting.
12. Enable running on macOS. This is sort of done - I enabled macCatalyst and Fouris runs on my Mac, but it looks not terribly good and needs a lot of work...
## Game Play
Game play consists of the user moving a dropping block into a bucket, trying to fit pieces together the best possible. When a row in a bucket is full of pieces, it is removed and all rows above it are dropped down.

The user can use the build-in controls for moving the piece or use on-screen touches (taps and swipes) to move the pieces.

In most game modes, once a user's piece freezes (eg, no longer able to move) in place above the outer edge of the bucket, the game is over.

When playing with a rotating bucket (most game modes), once a piece is frozen in a valid location, the contents and bucket rotate by 90°. Then, a new piece starts dropping. 

Inside-out mode is when the piece originates in the middle of a fully-enclosed bucket and starts dropping. After each piece freezes, the bucket and contents rotates as a rotating game would.
## Program Structure and Flow
When the game first starts, it waits a certain amount of time before starting playing in attract mode. (The amount of time is determined by a value in user settings.) (Attract mode is the same as using the AI.) The user can start playing at any time, aborting the attract mode.

If started in attract mode, game play will continue until the AI makes a mistake (which happens all too often) and the game is over. Fouris will wait a certain amount of time (about ten seconds), and if the user hasn't started a game, will start playing another game in attact mode (and continue the loop until the user starts playing or the game is exited).
## Documentation
This documentation was generated with Jazzy using the command:

`jazzy --min-acl internal --min-acl private --min-acl fileprivate --author "Stuart Rankin"`