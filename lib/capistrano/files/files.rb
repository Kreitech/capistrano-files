
def tmp_path(file)
  "tmp/#{string_timestamp}_#{File.basename(file)}"
end

def string_timestamp
  Time.now.strftime('%Y%m%dT%H%M%S')
end

def remote_path(file)
  File.join(shared_path, file)
end

def remote_file_exists?(file)
  test("[ -f #{file} ]")
end

def prompt(msg, prompt = "(y)es, (n)o ")
  ask(:answer, "#{msg} #{prompt} ? ")
  (fetch(:answer) =~ /^y$|^yes$/i) == 0
end

def diff_files(file1, file2)
  `git diff --no-index --color=always --ignore-space-at-eol #{file1} #{file2}`
end

def symlink(source, link)
  sudo "ln -f #{shared_path}/#{source} #{link}"
end


namespace :files do

  desc 'Symlink files using set :file_symlinks'
  task :symlink do
    on roles(:app) do
      symlinks = fetch(:file_symlinks) || []

      symlinks.each do |s|
        symlink(s[:source],s[:link])
      end
    end
  end

  after 'deploy:symlink:release', 'files:symlink'

  desc 'Uploads and prompts confirmation with diff'
  task :upload do
    on roles(:app) do
      files = fetch(:file_uploads) || []

      files.each do |file_metadata|
        destination_path = remote_path(file_metadata[:destination])
        tmp_path         = tmp_path(file_metadata[:destination])
        origin_path      = file_metadata[:origin]

        exists = remote_file_exists?(destination_path)

        if exists
          download!(destination_path, tmp_path)
          diff = diff_files(tmp_path, origin_path)
        end

        if (!exists || (!diff.empty? && prompt("#{diff} \nUpdate ?")))
          upload!(origin_path, destination_path)
        end
      end
    end
  end
end

