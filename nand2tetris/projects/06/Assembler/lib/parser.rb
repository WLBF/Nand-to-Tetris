#!/usr/bin/env ruby

module ParserModule
    class Parser
        def initialize(stream)
            @inputStream = stream
            @currentCmd
        end

        def reseek
            @inputStream.rewind
            @inputStream.lineno
        end

        def isCommand(line)
            return (/^[\/|\s]*(\/+.*|\s*)$/.match(line)).nil?
        end

        def hasMoreCommands
            while !@inputStream.eof?
                tmpLine = @inputStream.readline
                if isCommand(tmpLine)
                    len = tmpLine.length
                    @inputStream.seek(-len, IO::SEEK_CUR)
                    return true
                end
            end
            return false
        end

        def advance
            @currentCmd = @inputStream.readline.split('//')[0].delete(" ").delete("\n")
        end
    
        def commandType
            return case @currentCmd
            when /^@/
                :A_COMMAND
            when /^[^\(^\)^@]+$/
                :C_COMMAND
            when /^\(.+\)$/
                :L_COMMAND
            else
                raise "Command Type Error"
            end
        end

        def symbol
            return case commandType
            when :A_COMMAND
                @currentCmd[1..-1]
            when :L_COMMAND
                @currentCmd[1..-2]
            else
                raise "Symbol Error"
            end
        end

        def dest
            return (@currentCmd[/^([^;^=]+)\=/, 1] or "")
        end

        def comp
            return (@currentCmd[/\=([^;^\=]+)/, 1] or @currentCmd[/^[^;]+/])
        end

        def jump
            return (@currentCmd[/;(.+)/, 1] or "")
        end
    end
end