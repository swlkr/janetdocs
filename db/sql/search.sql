select
  binding.id,
  binding.name,
  binding.docstring,
  binding.package_id,
  package.name as package,
  count(example.id) as examples
from
  binding
left outer join
  package on binding.package_id = package.id
left outer join
  example on example.binding_id = binding.id
where
  binding.name like ?
group by
  binding.id
