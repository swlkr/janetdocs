select
  *
from
  binding
where
  binding.id = (abs(random()) % (select (select max(binding.id) from binding) + 1))
