# ArchAngel
## Installation
1. Install [Vagrant](http://downloads.vagrantup.com/) for your OS
2. Ensure you have a git client (try [SourceTree](http://www.sourcetreeapp.com/) if you don't have one)
3. Clone [our repository](https://github.com/dhm116/ArchAngel): `git clone https://github.com/dhm116/ArchAngel` from the command line, or use your git gui
4. Open a shell prompt where you checked out ArchAngel and type `vagrant up`
5. Go get a snack while vagrant downloads Ubuntu 13.04, installs PostgreSQL and NodeJS
6. When complete, simply type `vagrant ssh` to gain access to the VM
7. Your ArchAngel folder is mounted on the VM at `/vagrant_data`, so any web apps would run from that location
8. Ports 22 (ssh), 3333 (for node app) and 5432 (postgres) are automatically forwarded to your local machine, so you can access them as if they were running directly on your OS