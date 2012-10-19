describe 'Jbuilder integration' do
  context 'dependency loading with Jbuilder' do
    before do
      Object.const_set(:Jbuilder, Class.new)
      Gem.loaded_specs["jbuilder"] = Gem::Specification.new("jbuilder_fake", "0.5.0")
    end

    after do
      Object.send(:remove_const, "Jbuilder")
      Gem.loaded_specs["jbuilder"] = nil
    end

    it 'does not require BlankSlate' do
      expect{ require 'gon'}.not_to raise_error
    end
  end
end
