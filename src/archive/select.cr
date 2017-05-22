module Archive
	class DirExistsException < Exception end
	class Select
		@dirname : String
		@ignored_dirs  : Array(String)
		@ignored_files : Array(String) 
		@ignored_exts  : Array(String)

		@files : Array(String)

		getter files

		def initialize (
			@dirname,
			@ignored_dirs  = [] of String,
			@ignored_exts  = [] of String,
			@ignored_files = [] of String
		)
			# check the existance if @dirname, except if it failed
			unless Dir.exists? @dirname
				raise DirExistsException.new "\"#{@dirname}\" don't exists !"
			end

			# normalize @dirname, i.e. remove all / or \
			while @dirname[-1] == File::SEPARATOR
				@dirname = @dirname[0, @dirname.size - 1]
			end

			@files = [] of String
		end

		def analyze ( dir = @dirname )
			waiting_dirs = [] of String

			Dir.foreach dir do |e|
				if e != "." && e != ".."

					check = true

					# check for ignored directories					
					@ignored_dirs.each do |d|
						if e == d
							check = false
							break
						end
					end

					# check for ignored extensions
					@ignored_exts.each do |ext|
						if File.extname(e) == ("." + ext)
							check = false
							break
						end
					end

					# check for ignored files
					@ignored_files.each do |f|
						if e == f
							check = false
							break
						end
					end

					if check
						# file with precedent dirname
						file = dir + File::SEPARATOR + e

						# if it's a dir, add to waiting directories, else add to @files
						if Dir.exists? file
							waiting_dirs << file
						else
							@files << file
						end
					end
				end
			end

			waiting_dirs.each do |d|
				analyze d
			end
		end

	end
end
