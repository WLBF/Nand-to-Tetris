require 'parser'

describe ParserModule::Parser do
    describe "#isCommand" do
        context "Determine the line is command or not" do
            it "Should return false if the line is a comment" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                expect(instance.isCommand("// this is a comment\n")).to eq false
                expect(instance.isCommand("    // this is a comment\n")).to eq false
            end

            it "Should return false if the line is blank" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                expect(instance.isCommand("\n")).to eq false
                expect(instance.isCommand("    \n")).to eq false
            end

            it "Should return true if the text line is a command" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                expect(instance.isCommand("@R0\n")).to eq true
                expect(instance.isCommand("    @R0\n")).to eq true
                
                expect(instance.isCommand("D=D-M\n")).to eq true
                expect(instance.isCommand("    D=D-M\n")).to eq true
                
                expect(instance.isCommand("(OUTPUT_FIRST)\n")).to eq true
                expect(instance.isCommand("    (OUTPUT_FIRST)\n")).to eq true
            end
        end
    end

    describe "#hasMoreCommands" do
        context "Determine is there more command line in text stream" do
            it "Should return false if give a comment or blank text lines" do
                ParserArr = []
                4.times do ParserArr << StringIO.new end
                ParserArr[0].puts("\n")
                ParserArr[1].puts("       \n")
                ParserArr[2].puts("// this is a comment\n")
                ParserArr[3].puts("\n// this is a comment\n       \n")
                ParserArr.each do |io|
                    io.rewind
                    io.lineno
                    instance = ParserModule::Parser.new(io)
                    expect(instance.hasMoreCommands).to eq false
                end
            end

            it "Should return true if there command in text lines" do
                ParserArr.clear
                4.times do ParserArr << StringIO.new end
                ParserArr[0].puts("\n  (label)\n// this is a comment\n       \n")
                ParserArr[1].puts("\n// this is a comment\n  D=D-M\n       \n")
                ParserArr[2].puts("\n// this is a comment\n       \n  @LOOP")
                ParserArr[3].puts("  0;JMP\n// this is a comment\n       \n")
                ParserArr.each do |io|
                    io.rewind
                    io.lineno
                    instance = ParserModule::Parser.new(io)
                    expect(instance.hasMoreCommands).to eq true
                end
            end
        end
    end

    describe "#advance" do
        context "Reads the next command from the input and makes it the current command" do
            it "Should remove all whitespace and comment" do
                ParserArr.clear
                8.times do ParserArr << StringIO.new end
                textArr = [
                    "(label)\n",
                    "    (label)// this is a comment\n",
                    "@LOOP\n",
                    "    @LOOP// this is a comment\n",
                    "D=D-M\n",
                    "    D=D-M// this is a comment\n",
                    "0;JMP\n",
                    "    0;JMP// this is a comment\n",
                ]
                commandArr = [
                    "(label)",
                    "(label)",
                    "@LOOP",
                    "@LOOP",
                    "D=D-M",
                    "D=D-M",
                    "0;JMP",
                    "0;JMP",
                ]
                ParserArr.zip(textArr, commandArr).each do |io, text, command|
                    io.puts(text)
                    io.rewind
                    io.lineno
                    instance = ParserModule::Parser.new(io)
                    instance.advance
                    expect(instance.instance_variable_get(:@currentCmd)).to eq command
                end
            end
        end
    end

    describe "#commandType" do
        context "Returns the type of the current command" do
            it "Should return :A_COMMAND" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                instance.instance_variable_set(:@currentCmd, "@LOOP")
                expect(instance.commandType).to eq :A_COMMAND
            end

            it "Should return :C_COMMAND" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                instance.instance_variable_set(:@currentCmd, "D=D-M")
                expect(instance.commandType).to eq :C_COMMAND
                instance.instance_variable_set(:@currentCmd, "0;JMP")
                expect(instance.commandType).to eq :C_COMMAND
            end

            it "Should return :L_COMMAND" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                instance.instance_variable_set(:@currentCmd, "(label)")
                expect(instance.commandType).to eq :L_COMMAND
            end
        end
    end

    describe "#symbol" do
        context "Returns the symbol or decimal xxx of the current command" do
            it "Should return symbol in a A-command" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                allow(instance).to receive(:commandType).and_return(:A_COMMAND)
                instance.instance_variable_set(:@currentCmd, "@LOOP")
                expect(instance.symbol).to eq "LOOP"
                instance.instance_variable_set(:@currentCmd, "@333")
                expect(instance.symbol).to eq "333"
            end

            it "Should return symbol in a L-command" do
                io = StringIO.new
                instance = ParserModule::Parser.new(io)
                allow(instance).to receive(:commandType).and_return(:L_COMMAND)
                instance.instance_variable_set(:@currentCmd, "(label)")
                expect(instance.symbol).to eq "label"
                instance.instance_variable_set(:@currentCmd, "(333)")
                expect(instance.symbol).to eq "333"
            end
        end
    end

    describe "#dest" do
        context "Returns the dest mnemonic in the current C-command" do
            io = StringIO.new
            instance = ParserModule::Parser.new(io)
            it "Should return 'D' when given 'D=D-A'" do
                instance.instance_variable_set(:@currentCmd, "D=D-A")
                expect(instance.dest).to eq "D"
            end
            
            it "Should return empty string '' when given '0;JMP'" do
                instance.instance_variable_set(:@currentCmd, "0;JMP")
                expect(instance.dest).to eq ""
            end

            it "Should return 'D' when given 'D=D-A;JMP'" do
                instance.instance_variable_set(:@currentCmd, "D=D-A;JMP")
                expect(instance.dest).to eq "D"
            end
        end
    end

    describe "#comp" do
        context "Returns the comp mnemonic in the current C-command" do
            io = StringIO.new
            instance = ParserModule::Parser.new(io)
            it "Should return 'D-A' when given 'D=D-A'" do
                instance.instance_variable_set(:@currentCmd, "D=D-A")
                expect(instance.comp).to eq "D-A"
            end
            
            it "Should return '0' when given '0;JMP'" do
                instance.instance_variable_set(:@currentCmd, "0;JMP")
                expect(instance.comp).to eq "0"
            end

            it "Should return 'D-A' when given 'D=D-A;JMP'" do
                instance.instance_variable_set(:@currentCmd, "D=D-A;JMP")
                expect(instance.comp).to eq "D-A"
            end
        end
    end

    describe "#jump" do
        context "Returns the jump mnemonic in the current C-command" do
            io = StringIO.new
            instance = ParserModule::Parser.new(io)
            it "Should return empty string '' when given 'D=D-A'" do
                instance.instance_variable_set(:@currentCmd, "D=D-A")
                expect(instance.jump).to eq ""
            end
            
            it "Should return 'JMP' when given '0;JMP'" do
                instance.instance_variable_set(:@currentCmd, "0;JMP")
                expect(instance.jump).to eq "JMP"
            end

            it "Should return 'JMP' when given 'D=D-A;JMP'" do
                instance.instance_variable_set(:@currentCmd, "D=D-A;JMP")
                expect(instance.jump).to eq "JMP"
            end
        end
    end
end

