require 'rake'
require 'pathname'

ASM = 'vasm6502_oldstyle'
RP6502 = '../cc65-template/tools/rp6502.py'

target = 'smon'

if ENV['address'].nil?
  address = '0xE000'
else
  address = ENV['address']
end


desc "Run it"
task :run do
  sh "#{RP6502} -D /dev/ttyUSB0 --noreset run #{target}.rp6502"
end

desc "Upload it"
task :upload do
  sh "#{RP6502} -D /dev/ttyUSB0 upload #{target}.rp6502"
end

desc 'clean build'
task :clean do
  FileUtils.rm(["#{target}.bin", "#{target}.rp6502", "#{target}.lst"])
end

desc 'default is to build'
task :default => [:build]

desc 'build file'
task :build => ["#{target}.rp6502"]

file "#{target}.bin" => ["#{target}.asm", "config.asm", "ria.asm", "kernal.asm"] do |t|
  puts "Assembling #{t.source}"
  sh "#{ASM} -Fbin -dotdir -wdc02 -L #{File.basename(t.source).ext('lst')} -o #{t.name} #{t.source}"
end

# extract the vectors from the .lst file and generate .rp6502
file "#{target}.rp6502" => ["#{target}.bin"] do |t|
  puts "Extracting Vectors"
  irq= nil
  nmi= nil
  reset= nil
  File.open "#{target}.lst" do |file|
    file.find { |line| line =~ /Symbols by name:/ }
    irq = file.find { |line| line =~ /IRQ/ }
    nmi = file.find { |line| line =~ /NMI/ }
    reset = file.find { |line| line =~ /RESET/ }
  end

  unless irq.nil?
    irq = irq[/A:(....)/, 1]
    puts "IRQ @ #{irq}"
  end
  unless nmi.nil?
    nmi = nmi[/A:(....)/, 1]
    puts "NMI @ #{nmi}"
  end
  unless reset.nil?
    reset = reset[/A:(....)/, 1]
    puts "RESET @ #{reset}"
  end

  irqv = irq.nil? ? "" : "-i 0x#{irq}"
  nmiv = nmi.nil? ? "" : "-n 0x#{nmi}"
  resetv = reset.nil? ? "" : "-r 0x#{reset}"

  puts "ROMing #{t.source}"
  sh "#{RP6502} -a #{address} #{resetv} #{irqv} #{nmiv} -o #{t.name} create #{t.source}"
end

