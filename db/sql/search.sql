select
  binding.name,
  binding.docstring,
  package.name as package
from
  binding
join
  package on binding.package_id = package.id
where
  binding.name like ?
