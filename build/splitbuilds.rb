require 'builder'
require 'fileutils'

deploy0Path = '../build/deploy0'
deploy1Path = '../build/deploy1'
deploy2Path = '../build/deploy2'
deploy3Path = '../build/deploy3'
srcPath = '../src'

$namesMap = Hash["layouts" => "Layout",
					"objects" => "CustomObject",
					"applications" => "CustomApplication",
					"classes" => "ApexClass",
					"pages" => "ApexPage",
					"tabs" => "CustomTab"
				]
$API_VERSION = 44.0
def createDir(pathToDir)
	if Dir.exist?(pathToDir)
		puts "Deleting dir #{pathToDir}"
		FileUtils.remove_dir(pathToDir,:force=>false)
	else
		puts "dir not exists #{pathToDir}"
	end
	puts "making directory #{pathToDir}"
	FileUtils.mkdir_p("#{pathToDir}/src")
end

def get_List_Of_Folder(pathForDir)
	listOfFolder =  Dir.entries("#{pathForDir}").select {
		|entry|
		File.directory? File.join("#{pathForDir}",entry) and !(entry =='.' || entry == '..')
	}
	return listOfFolder
end

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
#    p.name "Test"
  end
end

def create_Package_xml(pathForPackageXml, listOfContent)
	testSFDCPackageFile = File.new("#{pathForPackageXml}/package.xml","w")
	testSFDCPackageFile.puts package_xml(listOfContent)
	testSFDCPackageFile.close
end

createDir(deploy0Path)
createDir(deploy1Path)
createDir(deploy2Path)
createDir(deploy3Path)

puts "\n\n\n"
puts " ********************* The Show Starts **************************    "
puts "\n\n\n"


puts "copying objects folder"
FileUtils.cp_r "#{srcPath}/objects", "#{deploy1Path}/src/"

puts "copying layouts folder"
FileUtils.cp_r "#{srcPath}/layouts", "#{deploy1Path}/src/"

puts "copying Application folder"
FileUtils.cp_r "#{srcPath}/applications", "#{deploy2Path}/src/"

puts "copying Classes folder"
FileUtils.cp_r "#{srcPath}/classes", "#{deploy2Path}/src/"

puts "copying pages folder"
FileUtils.cp_r "#{srcPath}/pages", "#{deploy2Path}/src/"

puts "copying tabs folder"
FileUtils.cp_r "#{srcPath}/tabs", "#{deploy2Path}/src/"

puts "\n\nTime to Create Package.xml\n\n"

puts "Creating Package.xml in #{deploy0Path}"
listOfFolder  = get_List_Of_Folder("#{deploy0Path}/src")
create_Package_xml("#{deploy0Path}/src/", listOfFolder)

puts "Creating Package.xml in #{deploy1Path}"
listOfFolder = get_List_Of_Folder("#{deploy1Path}/src")
create_Package_xml("#{deploy1Path}/src/", listOfFolder)

puts "Creating Package.xml in #{deploy2Path}"
listOfFolder = get_List_Of_Folder("#{deploy2Path}/src")
create_Package_xml("#{deploy2Path}/src/", listOfFolder)

puts "Creating Package.xml in #{deploy3Path}"
listOfFolder = get_List_Of_Folder("#{deploy3Path}/src")
create_Package_xml("#{deploy3Path}/src/", listOfFolder)






