<template>
  <v-card color="foreground">
    <v-fade-transition>
      <v-progress-linear
        indeterminate
        v-if="isLoading"
        color="primary"
        bottom
      />
    </v-fade-transition>
    <v-card-title class="subheading primary font-weight-bold"
      >Update</v-card-title
    >
    <v-card-text class="mt-2"
      >Update Dockyard to the latest version. <br />
      Note: This will spin up a run-once watchtower instance and update Dockyard.
      In the process Dockyard will be restarted and you will be logged
      out.</v-card-text
    >
    <v-btn
      class="mx-5 mb-5"
      color="primary"
      @click="update()"
      :disabled="!updatable"
    >
      Update Dockyard
    </v-btn>
  </v-card>
</template>

<script>
import axios from "axios";
import { mapMutations, mapActions, mapState } from "vuex";
export default {
  data() {
    return {
      containerDialog: false,
      isLoading: false,
      updatable: false
    };
  },
  mounted() {
    this.checkUpdate();
  },
  methods: {
    ...mapMutations({
      setMessage: "snackbar/setMessage",
      setErr: "snackbar/setErr"
    }),
    ...mapState({
      authDisabled: "auth/authDisabled"
    }),
    ...mapActions({
      logout: "auth/AUTH_LOGOUT"
    }),
    checkUpdate() {
      this.isLoading = true;
      axios({
        url: "/api/settings/check/update",
        method: "GET",
        responseType: "text/json"
      })
        .then(response => {
          this.isLoading = false;
          this.updatable = response.data;
        })
        .catch(err => {
          this.isLoading = false;
          this.setErr(err);
        });
    },
    update() {
      this.isLoading = true;
      axios({
        url: "/api/settings/update",
        method: "GET",
        responseType: "text/json"
      })
        .then(response => {
          this.isLoading = false;
          console.log(response.data);
          this.setMessage(
            "Dockyard is updating now. You will be logged out to complete the update."
          );
        })
        .finally(() => {
          this.isLoading = true;
          const sleep = delay =>
            new Promise(resolve => setTimeout(resolve, delay));
          sleep(5000);
          if (this.authDisabled == true) {
            this.$forceUpdate();
          } else {
            this.logout();
            this.$forceUpdate();
          }
        })
        .catch(err => {
          this.isLoading = false;
          this.setErr(err);
        });
    }
  }
};
</script>
