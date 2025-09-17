# SDDM Sugar Candy Theme

You asked for more, you shall get it. Sugar Candy is the latest release in the Sugar series of SDDM themes. It's so extremely sweet your pancreas will have difficulties digesting its awesomeness.  

Sweeten the login experience for your users, your family and yourself. Sugar Candy works on almost all major distributions and focuses on a straight forward user experience and superb functionality while still offering vast customization possibilities.  

Sugar Candy is based on the Sugar series which was **written completely from scratch** making it clean and simple not only by looks but by design too.  
All controls use the [latest Qt Quick Controls 2](http://doc.qt.io/qt-5/qtquickcontrols2-index.html) for [increased performance](https://blog.qt.io/blog/2015/03/31/qt-quick-controls-for-embedded/) on low end or even embedded systems and beautiful color transitions.  

To learn how to control sugar levels read the section below about customization. Your secret sauce is located at ./sddm/themes/sugar-candy/theme.conf! There are **46 customizable variables** in total! This candy will be yours and only yours.  

## Installation  

**From within KDE Plasma**  

If you are on [KDE Plasma](https://www.kde.org/plasma-desktop)—by default [Manjaro](https://manjaro.org/), [OpenSuse](https://www.opensuse.org/), [Neon](https://neon.kde.org/), [Kubuntu](https://kubuntu.org/), [KaOS](https://kaosx.us/) or [Chakra](https://www.chakralinux.org/) for example—you are lucky and can simply go to your system settings and under "Startup and Shutdown" followed by "Login Screen (SDDM)" click "Get New Theme". From there search for "Sugar Candy" and install.

If for some reason you cannot find the category named "Login Screen (SDDM)" in your system settings then you are missing the module `sddm-kcm`. Install this little helper with your package manager first. You will be grateful you did.

**From other desktop environments**  

Download the tar archive from the files tab of this web page and extract the contents to the theme directory of SDDM *(change the path for the downloaded file if necessary)*:  

`$ sudo tar -xzvf ~/sugar‑candy.tar.gz -C /usr/share/sddm/themes`  

This will extract all the files to a folder called "sugar‑candy" inside of the themes directory of SDDM.  

After that you will have to point SDDM to the new theme by editing its config file, preferrably at `/etc/sddm.conf` *(create if necessary)*. You can take the default config file of SDDM as a reference which might be found at: `/usr/lib/sddm/sddm.conf.d/sddm.conf`.  

In the `[Theme]` section simply add the themes name to this line: `Current=sugar‑candy`. If you don't care for SDDM options and you had to create the file from blank just add these two lines and save it. Also see the [Arch wiki on SDDM](https://wiki.archlinux.org/index.php/SDDM).  

## Dependencies

[SDDM  >= 0.18](https://github.com/sddm/sddm) & [Qt5 >= 5.11](https://doc.qt.io/archives/qt-5.11/index.html)  
including: [`Qt Quick Controls 2`](https://doc.qt.io/archives/qt-5.11/qtquickcontrols2-index.html), [`Qt Graphical Effects`](https://doc.qt.io/archives/qt-5.11/qtgraphicaleffects-index.html), [`Qt SVG`](https://doc.qt.io/archives/qt-5.11/qtsvg-index.html), [`Qt Quick Layouts`](https://doc.qt.io/archives/qt-5.11/qtquicklayouts-index.html) each `>= 5.11`—*see below for distro specific package names*  

*Make sure these are installed with their required version or higher! SDDM might need an enabled system service/daemon to work. This is often done automatically during installation. Take note that a lot of standard release distros like Debian, Mint, MX, Elementary, Deepin or Ubuntu LTS are still on earlier versions. If in doubt ask in your distros forums.*  

## Configuration

The sugar series is **extremely customizable** by editing its included `theme.conf` file or even better by overwriting default values in `theme.conf.user`. You can change the colors and images used, the time and date formats, the appearance of the whole interface and even how it works.  

The exact path to the theme.conf file differs ever so slightly from distro to distro. Most common ones are /usr/lib/sddm/themes and /usr/share/sddm/themes. Please refer to your distros manual.
Overwrite default values in theme.conf.user instead of theme.conf to prevent changes from being overwritten when I push an update.  

**Pro tip**: It's super annoying to log out and back in every time you want to see a change made to the `theme.conf` file. To preview your changes from withing your running desktop environment session simply issue:  
`sddm-greeter --test-mode --theme /usr/share/sddm/themes/sugar-candy`  

And as if that wouldn't still be enough you can **translate every single button and label** because SDDM still [needs your help](https://github.com/sddm/sddm/wiki/Localization) to make localization as complete as possible!  

## Legal Notice

This file is part of SDDM Sugar Candy.
A theme for the Simple Display Desktop Manager.

Copyright (C) 2018–2020 Marian Arlt

SDDM Sugar Candy is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version.

You are required to preserve this and any additional legal notices, either
contained in this file or in other files that you received along with
SDDM Sugar Candy that refer to the author(s) in accordance with
sections §4, §5 and specifically §7b of the GNU General Public License.

SDDM Sugar Candy is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SDDM Sugar Candy. If not, see <https://www.gnu.org/licenses/>

