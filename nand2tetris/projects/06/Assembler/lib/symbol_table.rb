module SymbolTableModule
    class SymbolTable
        def initialize
            @table = {
                "SP" => 0,
                "LCL" => 1,
                "ARG" => 2,
                "THIS" => 3,
                "THAT" => 4,
                "SCREEN" => 16384,
                "KBD" => 24576,
            }
        end

        def addEntry(symbol, address)
            @table[symbol] = address
        end

        def contains(symbol)
            return (!@table[symbol].nil? or !(symbol =~ /^R([0-9]|1[0-5])$/).nil?)
        end

        def getAddress(symbol)
            return (@table[symbol] or symbol[/^R([0-9]|1[0-5])$/, 1].to_i)
        end
    end
end