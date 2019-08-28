# Microphone Sound-Source-Localization

[![](https://img.shields.io/badge/Environment-Matlab-blue)](<https://github.com/xiaoli1368/Microphone-sound-source-localization>)  [![](https://img.shields.io/badge/Size-15.3Mb-orange)](<https://github.com/xiaoli1368/Microphone-sound-source-localization>)  [![](https://img.shields.io/badge/License-MIT-brightgreen)](<https://github.com/xiaoli1368/Microphone-sound-source-localization>)

The current project basically realizes the sound source positioning function simulation of tdoa-srp based on microphone array, and the overall code is developed based on Matlab, which can be well oriented, but there are still shortcomings in distance determination.

## Table of Contents

- [Introduction](#Introduction)
- [Usage](#usage)
- [License](#license)
- [Others](#others)

## Introduction

It is mainly implemented by the following two steps:

- first, time delays between channels are estimated using GCC-PHAT.
- then, srp-phat is used to estimate location of sound source.

In the second step, the method of spatial domain contraction is used. Even if the spherical coordinates are used for search, the search scope (referring to the Angle) is gradually narrowed. The sum of SRP in each Angle direction is calculated to measure whether the direction should be included in the contraction domain. But there is a big error in judging the distance, so we can only measure the Angle at present. For distance positioning, systematic analysis of geometry and SRP principle is needed.

In addition, some basic numerical methods are also used to solve the problem, and the results are also able to achieve angular positioning, but difficult to achieve distance positioning. More accurate positioning needs to be further improved on the algorithm level.

## Usage

1. The current code is run by matlab.

2. Here **tdoa_method.m** is the main program and can be run directly.

3. Mat file is the speech signal collected by four-channel microphone. If you want to use your own data, you can refer to the storage name of mat file and change it to your own speech file accordingly. If you want to use a multiplexed microphone, such as a 6-way model, it is more difficult and you need to modify all the four-way processing involved in all the code.

4. The coordinates of the microphone array model are initialized in the main program and can be modified when necessary.

5. There are several different subfunctions for sound source location called, of which only two major methods are srp-phat and numerical calculation.

## License

MIT © Richard McRichface

## Others

If you have any questions, please contact me.