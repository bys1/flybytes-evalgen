javac -cp rascal.jar -d build src/main/java/*/*.java
javac -cp rascal.jar -d build src/main/java/*/*/*.java
javac -cp rascal.jar -d build src/main/java/*/*/*/*.java
cd build
jar -cf fbeg.jar *