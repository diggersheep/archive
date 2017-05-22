require "zip"

module Archive

	class ZipArchive
		@target  : String
		@dirname : String

		@ignored_dirs  : Array(String)
		@ignored_ext   : Array(String)
		@ignored_files : Array(String)

		@files : Array(String)

		def initialize (
			@target,
			@dirname,
			@ignored_dirs  = [] of String,
			@ignored_ext   = [] of String,
			@ignored_files = [] of String,
		)
		
			tmp_file = File.open target, "w"
			tmp_file.close

			s = Archive::Select.new(@dirname, @ignored_dirs, @ignored_ext, @ignored_files)
			s.analyze

			@files = s.files
		end

		def compress ( verbose = false )
			
			File.open(@target, "w") do |file|
				puts "archive \"#{@target}\""

				Zip::Writer.open(file) do |zip|
					@files.each do |filename|

						# subtratract  ./ and ../ directories
						while (md1 = /^.\//.match(filename)) || (md2 = /^..\//.match(filename))
							if md1
								filename = filename[2, filename.size - 2]
								next
							end

							if md2
								filename = filename[3, filename.size - 3]
								next
							end
						end

						begin
							zip.add( filename, File.open(filename) )
							puts "add \"#{filename}\""
						rescue
							puts "failed to add \"#{filename}\""
						end
					end
				end
			end 

		end

	end	

end
