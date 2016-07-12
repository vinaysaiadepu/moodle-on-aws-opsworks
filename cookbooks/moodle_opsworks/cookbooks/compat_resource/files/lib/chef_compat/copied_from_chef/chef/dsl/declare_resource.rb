begin
  require 'chef/dsl/declare_resource'
rescue LoadError; end

require 'chef_compat/copied_from_chef'
class Chef
module ::ChefCompat
module CopiedFromChef
#--
# Author:: Adam Jacob (<adam@chef.io>)
# Author:: Christopher Walters
# Copyright:: Copyright 2008-2016, 2009-2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


class Chef < (defined?(::Chef) ? ::Chef : Object)
  module DSL
    CopiedFromChef.extend_chef_module(::Chef::DSL, self) if defined?(::Chef::DSL)
    module DeclareResource
      CopiedFromChef.extend_chef_module(::Chef::DSL::DeclareResource, self) if defined?(::Chef::DSL::DeclareResource)

      # Helper for switching run_contexts.  Allows for using :parent or :root in place of
      # passing the run_context.  Executes the block in the run_context.  Returns the return
      # value of the passed block.
      #
      # @param rc  [Chef::RunContext,Symbol] Either :root, :parent or a Chef::RunContext
      #
      # @return return value of the block
      #
      # @example
      #   # creates/returns a 'service[foo]' resource in the root run_context
      #   resource = with_run_context(:root)
      #     edit_resource(:service, "foo") do
      #       action :nothing
      #     end
      #   end
      #
      def with_run_context(rc)
        raise ArgumentError, "with_run_context is useless without a block" unless block_given?
        old_run_context = @run_context
        @run_context =
          case rc
          when Chef::RunContext
            rc
          when :root
            Chef.run_context
          when :parent
            run_context.parent_run_context
          else
            raise ArgumentError, "bad argument to run_context helper, must be :root, :parent, or a Chef::RunContext"
          end
        yield
      ensure
        @run_context = old_run_context
      end

      # Lookup a resource in the resource collection by name and delete it.  This
      # will raise Chef::Exceptions::ResourceNotFound if the resource is not found.
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      #
      # @return [Chef::Resource] The resource
      #
      # @example
      #   delete_resource!(:template, '/x/y.txy')
      #
      def delete_resource!(type, name, run_context: self.run_context)
        run_context.resource_collection.delete("#{type}[#{name}]")
      end

      # Lookup a resource in the resource collection by name and delete it.  Returns
      # nil if the resource is not found and should not fail.
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      #
      # @return [Chef::Resource] The resource
      #
      # @example
      #   delete_resource(:template, '/x/y.txy')
      #
      def delete_resource(type, name, run_context: self.run_context)
        delete_resource!(type, name, run_context: run_context)
      rescue Chef::Exceptions::ResourceNotFound
        nil
      end

      # Lookup a resource in the resource collection by name and edit the resource.  If the resource is not
      # found this will raise Chef::Exceptions::ResourceNotFound.  This is the correct API to use for
      # "chef_rewind" functionality.
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      # @param resource_attrs_block A block that lets you set attributes of the
      #   resource (it is instance_eval'd on the resource instance).
      #
      # @return [Chef::Resource] The updated resource
      #
      # @example
      #   edit_resource!(:template, '/x/y.txy') do
      #     cookbook_name: cookbook_name
      #   end
      #
      def edit_resource!(type, name, created_at = nil, run_context: self.run_context, &resource_attrs_block)
        resource = find_resource!(type, name, run_context: run_context)
        resource.instance_eval(&resource_attrs_block) if block_given?
        resource
      end

      # Lookup a resource in the resource collection by name.  If it exists,
      # return it.  If it does not exist, create it.  This is a useful function
      # for accumulator patterns.  In CRUD terminology this is an "upsert" operation and is
      # used to assert that the resource must exist with the specified properties.
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param created_at [String] The caller of the resource.  Use `caller[0]`
      #   to get the caller of your function.  Defaults to the caller of this
      #   function.
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      # @param resource_attrs_block A block that lets you set attributes of the
      #   resource (it is instance_eval'd on the resource instance).
      #
      # @return [Chef::Resource] The updated or created resource
      #
      # @example
      #   resource = edit_resource(:template, '/x/y.txy') do
      #     source "y.txy.erb"
      #     variables {}
      #   end
      #   resource.variables.merge!({ home: "/home/klowns"  })
      #
      def edit_resource(type, name, created_at = nil, run_context: self.run_context, &resource_attrs_block)
        edit_resource!(type, name, created_at, run_context: run_context, &resource_attrs_block)
      rescue Chef::Exceptions::ResourceNotFound
        declare_resource(type, name, created_at, run_context: run_context, &resource_attrs_block)
      end

      # Lookup a resource in the resource collection by name.  If the resource is not
      # found this will raise Chef::Exceptions::ResourceNotFound.  This API is identical to the
      # resources() call and while it is a synonym it is not intended to deprecate that call.
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      #
      # @return [Chef::Resource] The updated resource
      #
      # @example
      #   resource = find_resource!(:template, '/x/y.txy')
      #
      def find_resource!(type, name, run_context: self.run_context)
        raise ArgumentError, "find_resource! does not take a block" if block_given?
        run_context.resource_collection.find(type => name)
      end

      # Lookup a resource in the resource collection by name.  If the resource is not found
      # the will be no exception raised and the call will return nil.  If a block is given and
      # no resource is found it will create the resource using the block, if the resource is
      # found then the block will not be applied.  The block version is similar to create_if_missing
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      #
      # @return [Chef::Resource] The updated resource
      #
      # @example
      #   if ( find_resource(:template, '/x/y.txy') )
      #     # do something
      #   else
      #     # don't worry about the error
      #   end
      #
      # @example
      #   # this API can be used to return a resource from an outer run context, and will only create
      #   # an action :nothing service if one does not already exist.
      #   resource = with_run_context(:root) do
      #     find_resource(:service, 'whatever') do
      #       action :nothing
      #     end
      #   end
      #
      def find_resource(type, name, created_at: nil, run_context: self.run_context, &resource_attrs_block)
        find_resource!(type, name, run_context: run_context)
      rescue Chef::Exceptions::ResourceNotFound
        if block_given?
          declare_resource(type, name, created_at, run_context: run_context, &resource_attrs_block)
        end # returns nil otherwise
      end

      # Instantiates a resource (via #build_resource), then adds it to the
      # resource collection. Note that resource classes are looked up directly,
      # so this will create the resource you intended even if the method name
      # corresponding to that resource has been overridden.
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param created_at [String] The caller of the resource.  Use `caller[0]`
      #   to get the caller of your function.  Defaults to the caller of this
      #   function.
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      # @param resource_attrs_block A block that lets you set attributes of the
      #   resource (it is instance_eval'd on the resource instance).
      #
      # @return [Chef::Resource] The new resource.
      #
      # @example
      #   declare_resource(:file, '/x/y.txy', caller[0]) do
      #     action :delete
      #   end
      #   # Equivalent to
      #   file '/x/y.txt' do
      #     action :delete
      #   end
      #
      def declare_resource(type, name, created_at = nil, run_context: self.run_context, create_if_missing: false, &resource_attrs_block)
        created_at ||= caller[0]

        if create_if_missing
          Chef::Log.deprecation "build_resource with a create_if_missing flag is deprecated, use edit_resource instead"
          # midly goofy since we call edit_resource only to re-call ourselves, but that's why its deprecated...
          return edit_resource(type, name, created_at, run_context: run_context, &resource_attrs_block)
        end

        resource = build_resource(type, name, created_at, &resource_attrs_block)

        run_context.resource_collection.insert(resource, resource_type: type, instance_name: name)
        resource
      end

      # Instantiate a resource of the given +type+ with the given +name+ and
      # attributes as given in the +resource_attrs_block+.
      #
      # The resource is NOT added to the resource collection.
      #
      # @param type [Symbol] The type of resource (e.g. `:file` or `:package`)
      # @param name [String] The name of the resource (e.g. '/x/y.txt' or 'apache2')
      # @param created_at [String] The caller of the resource.  Use `caller[0]`
      #   to get the caller of your function.  Defaults to the caller of this
      #   function.
      # @param run_context [Chef::RunContext] the run_context of the resource collection to operate on
      # @param resource_attrs_block A block that lets you set attributes of the
      #   resource (it is instance_eval'd on the resource instance).
      #
      # @return [Chef::Resource] The new resource.
      #
      # @example
      #   build_resource(:file, '/x/y.txy', caller[0]) do
      #     action :delete
      #   end
      #
      def build_resource(type, name, created_at = nil, run_context: self.run_context, &resource_attrs_block)
        created_at ||= caller[0]

        # this needs to be lazy in order to avoid circular dependencies since ResourceBuilder
        # will requires the entire provider+resolver universe
        require "chef_compat/copied_from_chef/chef/resource_builder" unless defined?(Chef::ResourceBuilder)

        Chef::ResourceBuilder.new(
          type:                type,
          name:                name,
          created_at:          created_at,
          params:              @params,
          run_context:         run_context,
          cookbook_name:       cookbook_name,
          recipe_name:         recipe_name,
          enclosing_provider:  self.is_a?(Chef::Provider) ? self : nil
        ).build(&resource_attrs_block)
      end
    end
  end
end
end
end
end
