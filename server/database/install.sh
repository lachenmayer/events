

VERSION="neo4j-community-1.9"


if [ -d $VERSION ] ; then #Already Installed
	echo "Error: Neo4j is already Installed"
	exit
else
	echo "Installing Neo4j"
fi

if [ ! -f "./resources/"$VERSION"-unix.tar.gz" ] ; then
	echo "Warning: Neo4j install tar.gz not found"
	cd resources
	wget http://dist.neo4j.org/neo4j-community-1.9-unix.tar.gz
	cd ..
fi

echo "Extracting Neo4j.."
tar -xf ./resources/$VERSION-unix.tar.gz -C .






