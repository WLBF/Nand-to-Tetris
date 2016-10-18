require 'symbol_table'

describe SymbolTableModule::SymbolTable do
    instance = SymbolTableModule::SymbolTable.new()
    describe "#contains" do
        context "Check if symbol table contain the given symbol" do
            it "Should return true if given empty string 'SP'" do
                expect(instance.contains("SP")).to eq true
            end

            it "Should return true if given empty string 'R0'" do
                expect(instance.contains("R0")).to eq true
            end
            
            it "Should return true if given empty string 'R15'" do
                expect(instance.contains("R15")).to eq true
            end

            it "Should return false if given empty string 'R16'" do
                expect(instance.contains("R16")).to eq false
            end

            it "Should return false if given empty string 'noexist'" do
                expect(instance.contains("noexist")).to eq false
            end
        end
    end

    describe "#getAddress" do
        context "Returns the address associated with the symbol" do
            it "Should return 0 if given empty string 'SP'" do
                expect(instance.getAddress("SP")).to eq 0
            end

            it "Should return 0 if given empty string 'R0'" do
                expect(instance.getAddress("R0")).to eq 0
            end
            
            it "Should return 15 if given empty string 'R15'" do
                expect(instance.getAddress("R15")).to eq 15
            end
        end
    end

    describe "#addEntry" do
        context "Adds the pair (symbol ,address) to the table" do
            it "Add ('HHH', 666) to the table " do
                instance.addEntry("HHH", 666)
                expect(instance.contains("HHH")).to eq true
                expect(instance.getAddress("HHH")).to eq 666
            end
        end
    end    
end