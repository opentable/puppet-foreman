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

  def partition_tables
    PuppetX::TheForeman::Resources::PartitionTables.new(resource)
  end

  def partition_table
    if @ptable
      @ptable
    else
      ptable = partition_tables.read
      ptable['results'].each do |s|
        if s['name'] == resource[:name]
          @ptable = partition_tables.read(s['id'])
          break
        else
          @ptable = nil
        end
      end
    end
    @ptable
  end

  def id
    partition_table ? partition_table['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    config_hash = {
      'name'               => resource[:name],
      'layout'             => resource[:layout],
      'os_family'          => resource[:os_family]
    }

    partition_tables.create(config_hash)
  end

  def destroy
    partition_tables.delete(id)
    @ptable = nil
  end

  def layout
    partition_table ? partition_table['layout'] : nil
  end

  def layout=(value)
    partition_tables.update(id, { :layout => value })
  end

  def os_family
    partition_table ? partition_table['os_family'] : nil
  end

  def os_family=(value)
    partition_tables.update(id, { :os_family => value })
  end
end
