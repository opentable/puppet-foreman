Puppet::Type.type(:foreman_partitiontable).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/partitiontable'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.partition_tables
    PuppetX::TheForeman::Resources::PartitionTables.new(nil)
  end

  def self.instances
    tables = partition_tables.read
    tables.collect do |s|
      table_hash = {
        :name      => s['name'],
        :id        => s['id'],
        :layout    => s['layout'],
        :os_family => s['os_family'],
        :ensure    => :present
      }
      new(table_hash)
  
    end
  end

  def self.prefetch(resources)
    tables = instances
    resources.keys.each do |table|
      if provider = tables.find { |t| t.name == table }
        resources[table].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    config_hash = {
      'name'               => resource[:name],
      'layout'             => resource[:layout],
      'os_family'          => resource[:os_family]
    }

    self.class.partition_tables.create(config_hash)
  end

  def destroy
    self.class.partition_tables.delete(id)
  end

  def id
    @property_hash[:id]
  end

  def name=(value)
    self.class.partition_tables.update(id, { :name => value })
  end

  def layout=(value)
    self.class.partition_tables.update(id, { :layout => value })
  end

  def os_family=(value)
    self.class.partition_tables.update(id, { :os_family => value })
  end

end
