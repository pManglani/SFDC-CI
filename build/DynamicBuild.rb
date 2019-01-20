require 'builder'
require 'fileutils'
require 'set'

$deployPath = '../build/deploy'

$namesMap = Hash["layouts" => "Layout",
					"objects" => "CustomObject",
					"applications" => "CustomApplication",
					"classes" => "ApexClass",
					"pages" => "ApexPage",
					"tabs" => "CustomTab"
				]
$setForPaths = Set.new()
$API_VERSION = 44.0

def createDir(pathToDir)
	if Dir.exist?(pathToDir)
		puts "Directory already exists #{pathToDir}"
	else
		puts "dir not exists #{pathToDir}"
		puts "making directory #{pathToDir}"
		FileUtils.mkdir_p("#{pathToDir}")
	end
end

def initSetForPaths
	File.readlines("../diffOutput.txt").each do |tempPath|
		tempPath = tempPath.strip()
		directoryName = File.dirname("#{tempPath}")
		puts "dirName is = #{directoryName}"
		if(directoryName!='build')
			fileExtName = File.extname(tempPath)
			$setForPaths.add(tempPath)
			if(fileExtName == '.cls' || fileExtName == '.page')
				fileName = File.basename(tempPath)
				fileName += '-meta.xml' 
				tempPath = tempPath.gsub(tempPath.split('/')[-1], fileName)
				$setForPaths.add(tempPath)
			end
		end
	end
end

def createBuildDirToDeploy
	initSetForPaths
	puts "\n\n\nIterating over paths\n\n\n"
	$setForPaths.each do |tempPath|
		puts "path is #{tempPath} "
		directoryName = File.dirname("#{tempPath}")
		createDir("#{$deployPath}/#{directoryName}")
		if File.exist?("../#{tempPath}")
			puts "copying content from  #{tempPath}"
			FileUtils.copy_file "../#{tempPath}", "#{$deployPath}/#{tempPath}"
		else
			puts "file not exist tempPath --> #{tempPath}"
		end
	end
end

#will return list of folder present in directory 
def get_List_Of_Folder(pathForDir)
	listOfFolder =  Dir.entries("#{pathForDir}").select {
		|entry|
		File.directory? File.join("#{pathForDir}",entry) and !(entry =='.' || entry == '..')
	}
	return listOfFolder
end

#will crete package xml on the base of list of folders
def package_xml(listOfFolder)
  xml = Builder::XmlMarkup.new( :indent => 4 )
  xml.instruct! :xml, :encoding => "UTF-8"
  xml.Package( "xmlns" => "http://soap.sforce.com/2006/04/metadata" ) do |p|
	listOfFolder.each do |item|
		p.types {
			|t|
			t.members "*"
			t.name $namesMap[item]
		}
	end
	p.version "#{$API_VERSION}"
  end
end

#will trigger the package.xml creation 
def create_Package_xml(pathForPackageXml, listOfContent)
	testSFDCPackageFile = File.new("#{pathForPackageXml}/package.xml","w")
	testSFDCPackageFile.puts package_xml(listOfContent)
	testSFDCPackageFile.close
end

createDir($deployPath)

puts "\n\n\n"
puts " ********************* Creating dynamic package **************************    "
puts "\n\n\n"

createBuildDirToDeploy

puts "\n\nTime to Create Package.xml\n\n"

puts "Creating Package.xml in #{$deployPath}"
listOfFolder  = get_List_Of_Folder("#{$deployPath}/src")
create_Package_xml("#{$deployPath}/src/", listOfFolder)