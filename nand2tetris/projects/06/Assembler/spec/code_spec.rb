require 'code'

describe CodeModule::Code do
    instance = CodeModule::Code.new()
    describe "#dest" do
        context "Returns the binary code of the dest mnemonic" do
            it "Should return '000' if given empty string ''" do
                expect(instance.dest("")).to eq "000"
            end

            it "Should return '101' if given empty string 'AM'" do
                expect(instance.dest("AM")).to eq "101"
            end
        end
    end

    describe "#comp" do
        context "Returns the binary code of the comp mnemonic" do
            it "Should return '0000010' if given empty string 'D+A'" do
                expect(instance.comp("D+A")).to eq "0000010"
            end
        end
    end

    describe "#jump" do
        context "Returns the binary code of the jump mnemonic" do
            it "Should return '000' if given empty string ''" do
                expect(instance.jump("")).to eq "000"
            end

            it "Should return '101' if given empty string 'JNE'" do
                expect(instance.jump("JNE")).to eq "101"
            end
        end
    end
end