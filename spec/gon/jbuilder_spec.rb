# frozen_string_literal: true

describe Gon do
  describe '.jbuilder' do
    context 'render jbuilder templates' do
      before do
        Gon.clear
        controller.instance_variable_set('@objects', objects)
      end

      let(:controller) { ActionController::Base.new }
      let(:objects) { [1, 2] }
      let(:template_path) { 'spec/test_data/sample.json.jbuilder' }

      it 'render json from jbuilder template' do
        Gon.jbuilder template: template_path, controller: controller
        expect(Gon.objects.length).to eq(2)
      end

      context 'with local variables' do
        let(:template_path) do
          'spec/test_data/sample_with_locals.json.jbuilder'
        end
        let(:local_variables) do
          { some_local: 1234, some_complex_local: OpenStruct.new(id: 1234) }
        end

        it 'render json from jbuilder template' do
          Gon.jbuilder template: template_path,
                       controller: controller,
                       locals: local_variables
          expect(Gon.some_local).to eq(1234)
          expect(Gon.some_complex_local_id).to eq(1234)
        end
      end

      context 'with helpers' do
        let(:template_path) do
          'spec/test_data/sample_with_helpers.json.jbuilder'
        end

        it 'render json from jbuilder template' do
          Gon.jbuilder template: template_path, controller: controller
          expect(Gon.date).to eq('about 6 hours')
        end
      end

      context 'with controller method' do
        let(:template_path) do
          'spec/test_data/sample_with_controller_method.json.jbuilder'
        end

        it 'render json from jbuilder template' do
          class << controller
            def private_controller_method
              'gon test helper works'
            end
            helper_method :private_controller_method
            private :private_controller_method
          end

          Gon.jbuilder template: template_path, controller: controller
          expect(Gon.data_from_method).to eq('gon test helper works')
        end
      end

      context 'with partial' do
        let(:template_path) do
          'spec/test_data/sample_with_partial.json.jbuilder'
        end

        it 'render json from jbuilder template' do
          controller.view_paths << 'spec/test_data'
          Gon.jbuilder template: template_path, controller: controller
          expect(Gon.objects.length).to eq(2)
        end
      end

      context 'within Rails' do
        before do
          # rubocop:disable Style/ClassAndModuleChildren
          module ::Rails; end
          # rubocop:enable Style/ClassAndModuleChildren

          msg_chain = 'application.routes.url_helpers.instance_methods'
          allow(Rails).to receive_message_chain(msg_chain) { [:user_path] }
          controller.instance_variable_set('@user_id', 1)
        end

        after do
          Object.send(:remove_const, :Rails)
        end

        let(:template_path) do
          'spec/test_data/sample_url_helpers.json.jbuilder'
        end

        it 'includes url_helpers' do
          expect(controller).to receive(:user_path) { |id| "/users/#{id}" }
          Gon.jbuilder template: template_path, controller: controller
          expect(Gon.url).to eq '/users/1'
        end
      end
    end
  end
end
