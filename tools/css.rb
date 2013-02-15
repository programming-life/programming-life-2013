#Formats CSS

input, output = ARGV

#Input
if input == nil or output == nil
    puts "Syntax: #{$0} [input] [output]"
    exit
end

#Opens file
unless File.exist? input
    puts "File #{input} doesn't exist."
    exit
end

#Reads file
input = File.read input
#Creates output file
output = File.new output, "w+"

#Processes input
input = input.gsub("{", "\n{\n\t")
         .gsub(",", ", ")
         .gsub(";", ";\n\t")
         .gsub(/\t?}/, "}\n\n\n")
         .gsub(/\t([^:]+):/, "\t" + '\1: ')

#Writes output
output.write input

#Closes output
output.close
