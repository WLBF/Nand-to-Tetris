#!/usr/bin/env ruby
require './parser'
require './code'
require './symbol_table'

class Assembler
    def initialize(inputStream, outputStream)
        @parser = ParserModule::Parser.new(inputStream)
        @code = CodeModule::Code.new()
        @output = outputStream
        @table = SymbolTableModule::SymbolTable.new()
    end

    def firstPass
        @parser.reseek
        num = 0
        while @parser.hasMoreCommands
            @parser.advance
            case @parser.commandType
            when :A_COMMAND
                num += 1
            when :C_COMMAND
                num += 1
            when :L_COMMAND
                @table.addEntry(@parser.symbol, num)
            end
        end
    end

    def secondPass
        @parser.reseek
        addr = 16
        while @parser.hasMoreCommands
            @parser.advance
            case @parser.commandType
            when :A_COMMAND
                symb = @parser.symbol
                if symb =~ /^[0-9]*$/
                    @output.write('%0*b' % [16, symb] + "\n")
                elsif @table.contains(symb)
                    @output.write('%0*b' % [16, @table.getAddress(symb)] + "\n")
                else
                    @table.addEntry(symb, addr)
                    @output.write('%0*b' % [16, addr] + "\n")
                    addr += 1
                end
            when :C_COMMAND
                des = @code.dest(@parser.dest)
                com = @code.comp(@parser.comp)
                jum = @code.jump(@parser.jump)
                @output.write("111"+ com + des + jum + "\n") 
            end
        end
    end
end

if __FILE__ == $0
    input = File.open(ARGV[0])
    output = File.open(ARGV[1], "w")
    assemb = Assembler.new(input, output)
    assemb.firstPass
    assemb.secondPass
    input.close
    output.close
end