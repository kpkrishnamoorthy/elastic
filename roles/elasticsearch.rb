name "elasticsearch"
description "Elasticsearch"
run_list(
  "recipe[java]",
  "recipe[elasticsearch]",
)

override_attributes({
  "starter_name" => "Krishnamoorthy Kp",
})
