require 'spec_helper'

describe Gon do

  describe '.jbuilder' do
    context 'render jbuilder templates' do

      before do
        Gon.clear
        controller.instance_variable_set('@objects', objects)
      end

      let(:controller) { ActionController::Base.new }
      let(:objects) { [1, 2] }

      it 'render json from jbuilder template' do
        Gon.jbuilder 'spec/test_data/sample.json.jbuilder', :controller => controller
        expect(Gon.objects.length).to eq(2)
      end

      it 'render json from jbuilder template with locals' do
        Gon.jbuilder 'spec/test_data/sample_with_locals.json.jbuilder',
                     :controller => controller,
                     :locals => { :some_local => 1234, :some_complex_local => OpenStruct.new(:id => 1234) }
        expect(Gon.some_local).to eq(1234)
        expect(Gon.some_complex_local_id).to eq(1234)
      end

      it 'render json from jbuilder template with locals' do
        Gon.jbuilder 'spec/test_data/sample_with_helpers.json.jbuilder', :controller => controller
        expect(Gon.date).to eq('about 6 hours')
      end

      it 'render json from jbuilder template with controller methods' do
        pending
        controller.instance_eval {
          def private_controller_method
            puts 'gon test helper works'
          end
          private :private_controller_method
        }

        Gon.jbuilder 'spec/test_data/sample_with_controller_method.json.jbuilder', :controller => controller
        expect(Gon.date).to eq('about 6 hours')
      end

      it 'render json from jbuilder template with a partial' do
        controller.view_paths << 'spec/test_data'
        Gon.jbuilder 'spec/test_data/sample_with_partial.json.jbuilder', :controller => controller
        expect(Gon.objects.length).to eq(2)
      end

    end

    it 'should raise error if you use gon.jbuilder without requiring jbuilder gem' do
      Gon.send(:remove_const, :Jbuilder)

      expect { Gon.jbuilder 'some_path' }.to raise_error
      load 'jbuilder.rb'
      load 'gon/jbuilder.rb'
    end

  end


  def request
    @request ||= double 'request', :env => {}
  end

end
