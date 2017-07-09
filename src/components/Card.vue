<template>
    <!-- Standard -->
    <div class="col-4">
      <b-card header="Card header text"
              class="mb-2"
              title="Card title"
              sub-title="Card subtitle"
              show-footer
              >
              <small slot="footer" class="text-muted">
                Last updated 3 mins ago
              </small>
      </b-card>
    </div>
</template>

<script>
export default {
  name: 'card'
}
</script>
