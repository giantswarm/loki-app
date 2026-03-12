package mc

import (
	"testing"
	"time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/apptest-framework/v3/pkg/state"
	"github.com/giantswarm/apptest-framework/v3/pkg/suite"
	"github.com/giantswarm/clustertest/v3/pkg/logger"
	appsv1 "k8s.io/api/apps/v1"
	"k8s.io/apimachinery/pkg/types"
)

const (
	isUpgrade        = false
	installNamespace = "loki"
)

func TestMC(t *testing.T) {
	suite.New().
		WithInstallNamespace(installNamespace).
		WithIsUpgrade(isUpgrade).
		WithValuesFile("./values.yaml").
		AfterClusterReady(func() {
			It("should connect to the management cluster", func() {
				Expect(state.GetFramework().MC().CheckConnection()).To(Succeed())
			})
		}).
		Tests(func() {
			// Write path
			It("should have loki-write statefulset ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking loki-write statefulset")
					var sts appsv1.StatefulSet
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "loki-write"}, &sts); err != nil {
						return false
					}
					return sts.Status.ReadyReplicas == *sts.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(10 * time.Minute).Should(BeTrue())
			})

			// Backend (indexing and compaction)
			It("should have loki-backend statefulset ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking loki-backend statefulset")
					var sts appsv1.StatefulSet
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "loki-backend"}, &sts); err != nil {
						return false
					}
					return sts.Status.ReadyReplicas == *sts.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(10 * time.Minute).Should(BeTrue())
			})

			// Read path
			It("should have loki-read deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking loki-read deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "loki-read"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(10 * time.Minute).Should(BeTrue())
			})

			// Entry point
			It("should have loki-gateway deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking loki-gateway deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "loki-gateway"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(10 * time.Minute).Should(BeTrue())
			})
		}).
		Run(t, "Loki MC test")
}
