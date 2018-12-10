#!/usr/bin/env bash

# link: https://intelmq.readthedocs.io/en/latest/Release/
# Update CHANHGELOG.md, NEWS.md and intelmq/version.py
# In git-root-dir insert new section for the new version
#		\->>> dch -v version		# version=a.b.c
#		\->>> dch -U	# opens editor


# check if pwd is set to git-root-dir
if ! [[ $(git rev-parse --show-toplevel 2>/dev/null) = "$PWD" ]]; then
	echo "$0: current directory is not the git-root-dir" > /dev/stderr
	exit 1
fi

root_branch=$(git branch -l | grep \* | sed -e 's/^* //')
release_branch="$root_branch-release"

# checks if DEB package exists
ls /opt | grep "intelmq_.*.deb" > /dev/null
if [[ $? -eq 0 ]]; then
	read -p "DEB package already exists in /opt. Would you like to continue? [y/n] " response
	if [ "$response" = "n" ]; then exit 0; fi 
fi

# Checkout to release branch
test $(git branch | grep release)
if [[ $? -gt 0 ]]; then
	git checkout -b "$release_branch"
else
	git checkout "$release_branch"
fi

# Make change in branch to commit
sed -i 's/UNRELEASED/unstable/' debian/changelog

# Updating version files if a new version is required
# read -p "Change the version in intelmq/version.py [y/n]?" response
# if [[ "$response" = "y" ]]; then vim intelmq/version.py; fi
# read -p "Change the version in debian/changelog [y/n]?" response
# if [[ "$response" = "y" ]]; then sed -i 's/UNRELEASED/unstable/' && dch -U; fi

git commit -am "REL: SK-CERT internal release commit"
# not important
# git tag 1.2.0 HEAD
python3 setup.py sdist bdist_wheel

# Create .deb package
regex="\(([a-z0-9.~-]+)\)" && [[ $(head -n 1 debian/changelog) =~ $regex ]] && debversion=${BASH_REMATCH[1]} && version=${debversion%-?}
git archive --format=tar.gz HEAD > ../intelmq_$version.orig.tar.gz
git archive --format=tar.gz --prefix=debian/ HEAD:debian/ > ../intelmq_$debversion.debian.tar.gz
pushd ..
mkdir build
cd build
tar -xzf ../intelmq_$version.orig.tar.gz
tar -xzf ../intelmq_$debversion.debian.tar.gz
popd
pushd ../build
DEB_BUILD_OPTIONS='nocheck' dpkg-buildpackage -us -uc -d
popd

# Remove release branch 
git checkout "$root_branch"
git branch -D "$release_branch"
