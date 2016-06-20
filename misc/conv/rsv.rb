#! /usr/bin/env ruby
# encoding: utf-8
require "find"
require "fileutils"
require "pathname"

# env
SRC_DIR = "src/"
DST_DIR = "dst/"
TEMP_FILE = DST_DIR + "temp" + $$.to_s + ".wav"

MPLAYER="/usr/bin/mplayer"
MP_OPT="-quiet -ao pcm:file="
LAME="/usr/bin/lame"
LM_OPT="-q 0 -a -b 32"
RM="rm"


# ececute command
# command: string
def cmd( command )
  if not system( command ) then
    p "Error: Exec: '" + command.to_s + "'"
    exit
  end
end

# convert main
# src: string, dst: string
def conv( src, dst )
  # p "CONV: '%s'" % src
  # p "    : '%s'" % dst

  if File.file?( dst ) then
    p "Warn: Dest alreay exist: '%s'" % dst
    return
  end

  dstdir = File.dirname( dst )
  if not File.directory?( dstdir ) then
    FileUtils.mkdir_p( dstdir )
  end

  cmd( MPLAYER + " " + MP_OPT + "\"" + TEMP_FILE + "\" \"" + src + "\"" )
  cmd( LAME + " " + LM_OPT + " \"" + TEMP_FILE + "\" \"" + dst + "\"" )
  cmd( RM + " \"" + TEMP_FILE + "\"" )
end


# main
def main( argv )
  if not File.directory?( SRC_DIR ) then
    p "Error: Src not exist: '%s'" % SRC_DIR
    exit
  end
  if not File.directory?( DST_DIR ) then
    if 0 != Dir.mkdir( DST_DIR ) then
      p "Error: Mkdir: '%s'" % DST_DIR
      exit
    end
  end

  Find.find( SRC_DIR ) do |f|
    if File.file?( f ) then
      conv( f.to_s,
            Pathname.new( f ).sub( SRC_DIR, DST_DIR ).sub_ext( ".mp3" ).to_s
          )
    end
  end
end
main ARGV
p " == done =="
