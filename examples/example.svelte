<script lang="ts">

const hello = "Hello";
const sayHello = (hi = "hey") => {
  return `${hi} world;
};
</script>

<p>{sayHello(hello)}</p>
