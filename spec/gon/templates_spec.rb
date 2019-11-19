# frozen_string_literal: true

describe Gon do
  describe '.template_path' do
    let(:template_path) { 'spec/test_data/sample.jbuilder' }

    context 'template is specified' do
      it 'add the extension if not included in the template name' do
        expect(Gon::EnvFinder.send(:template_path,
                                   { template: 'spec/test_data/sample' },
                                   'jbuilder')).to eql(template_path)
      end

      it 'return the specified template' do
        expect(Gon::EnvFinder.send(:template_path,
                                   { template: template_path },
                                   'jbuilder')).to eql(template_path)
      end
    end

    context 'template is not specified' do
      before do
        Gon.clear
        controller.instance_variable_set('@objects', objects)
        controller.action_name = 'show'
      end

      let(:controller) { ActionController::Base.new }
      let(:objects) { [1, 2] }

      context 'the action doesn as a template at a different format' do
        let(:template_path) do
          'app/views/action_controller/base/show.json.jbuilder'
        end
        it 'return the same template as the action with rabl extension' do
          expect(Gon::EnvFinder.send(:template_path,
                                     { controller: controller },
                                     'jbuilder')).to eql(template_path)
        end
      end
    end
  end
end
