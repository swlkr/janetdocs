select
  binding.id,
  binding.name,
  binding.docstring,
  binding.package_id,
  package.name as package
from
  binding
left outer join
  package on binding.package_id = package.id
where
  binding.name like ?
