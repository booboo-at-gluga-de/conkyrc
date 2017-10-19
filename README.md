The conkyrc sharing project
===========================

[Conky](https://github.com/brndnmtthws/conky) is a highly configurable system monitor tool for the X Window System.

We - some of the members of [GNU/Linux User Group Altdorf](https://gluga.de/) - use Conky. Because it has a very powerful configuration making so many things possible, we desided on our Meetup at 2017-10-18 to start the conkyrc sharing project.

In first place we want to share our conkyrc files here with each other and with the rest of the world so that we can learn from each other.

Next thing will be to set up pluggable system of prepared conkyrc blocks. This way a library will grow. Everybody than can easily pick the CPU usage block from here, the RAM usage block from there and can this way plug together his/her individual conkyrc with very low effort and without caring about all details of the conkyrc language. Stay curious!

Getting started
---------------

Install Conky, e. g. on Debian (in a root shell) by
```
apt-get install conky-all
```

Clone this git (under your user account)
```
mkdir ~/git
cd ~/git
git clone https://github.com/booboo-at-gluga-de/conkyrc.git
```

Symlink the conkyrc you want to try to ~/.conkyrc
```
cd
ln -s git/conkyrc/booboo/complete/conkyrc .conkyrc
```

Start conky
```
conky
```

How to contribute
-----------------

If you like our project, we would love to accept your pull request.

By contributing you declare that the files you contribute do not violate anybody else's rights, especially copyrights (this is quite easy if you did produce it yourself or it is derived from a file under GNU General Public License). And you agree that your contribution should be published under the GNU General Public License (GPL) v3, see LICENSE file.

Please make sure you keep our directory structure:
On top level create a directory with your name or nickname.
Directly under this directory you create a directory named "complete" for your complete conkyrc file or "includes" for your snippets.

Please do not add hidden files (starting with a dot).
Especially do not publish your .conkyrc under that name, but name it conkyrc instead or give it other meaningful names if you provide more of them.
