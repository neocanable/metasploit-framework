# -*- coding: binary -*-

###
#
# This mixin contains functionality which loads a Reflective
# DLL from disk into memory and finds the offset of the
# reflective loader's entry point.
#
###

module Msf::ReflectiveDLLLoader

  # Load a reflectively-injectable DLL from disk and find the offset
  # to the ReflectiveLoader function inside the DLL.
  #
  # @param dll_path Path to the DLL to load.
  #
  # @return [Array] Tuple of DLL contents and offset to the
  #                 +ReflectiveLoader+ function within the DLL.
  def load_rdi_dll(dll_path)
    dll = ''
    ::File.open(dll_path, 'rb') { |f| dll = f.read }

    offset = parse_pe(dll)

    return dll, offset
  end

  # Load a reflectively-injectable DLL from an string and find the offset
  # to the ReflectiveLoader function inside the DLL.
  #
  # @param [Integer] dll_data the DLL to load.
  #
  # @return [Integer] offset to the +ReflectiveLoader+ function within the DLL.
  def load_rdi_dll_from_data(dll_data)
    offset = parse_pe(dll_data)

    offset
  end

  private

  def parse_pe(dll)
    pe = Rex::PeParsey::Pe.new(Rex::ImageSource::Memory.new(dll))
    offset = nil

    pe.exports.entries.each do |e|
      if e.name =~ /^\S*ReflectiveLoader\S*/
        offset = pe.rva_to_file_offset(e.rva)
        break
      end
    end

    unless offset
      raise "Cannot find the ReflectiveLoader entry point in #{dll_path}"
    end

    offset
  end
end
