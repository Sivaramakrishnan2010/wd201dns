def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_records = {}
  dns_raw.each do
    |item|
    if item.start_with? "#"
      next
    elsif item == "\n"
      next
    else
      data = item.strip.split(",").map { |x| x.strip }
      dns_records[data[1]] = data
    end
  end
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records.key? domain
    if dns_records[domain][0] == "A"
      lookup_chain.push(dns_records[domain][2])
      return lookup_chain
    elsif dns_records[domain][0] == "CNAME"
      lookup_chain.push(dns_records[domain][2])
      resolve(dns_records, lookup_chain, dns_records[domain][2])
    end
  else
    lookup_chain.unshift("Error: record not found for")
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
