cd $(dirname $0)
cd ../complete
mvn clean package
rm -rf target
gradle build
rm -rf build
cd ../initial
mvn clean package
rm -rf target
gradle build
rm -rf build
exit $ret
