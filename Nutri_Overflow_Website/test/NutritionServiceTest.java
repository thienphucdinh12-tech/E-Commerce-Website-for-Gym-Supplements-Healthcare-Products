package test;

import utils.NutritionService;

public class NutritionServiceTest {

    public static void main(String[] args) {
        System.out.println("========== BẮT ĐẦU KIỂM THỬ NUTRITION SERVICE ==========");

        // Test Case 1: Local Vietnamese food (Phở bò)
        System.out.println("\n[Test Case 1] Tra cứu món ăn nội địa (Phở bò)...");
        NutritionService.FoodNutrition phoBo = NutritionService.getNutritionInfo("Phở bò");
        if (phoBo != null) {
            System.out.println("-> KẾT QUẢ THÀNH CÔNG:");
            System.out.println("   Tên món: " + phoBo.name);
            System.out.println("   Calo: " + phoBo.calories + " kcal");
            System.out.println("   Protein: " + phoBo.protein + " g");
            System.out.println("   Carb: " + phoBo.carbs + " g");
            System.out.println("   Fat: " + phoBo.fat + " g");
            System.out.println("   Khẩu phần: " + phoBo.servingSize);
            System.out.println("   Nguồn dữ liệu: " + phoBo.source);
            System.out.println("   Mô tả: " + phoBo.description);
            
            // Assert values
            if (phoBo.calories == 350 && "LOCAL".equals(phoBo.source)) {
                System.out.println("   => PASS");
            } else {
                System.out.println("   => FAIL (Sai lệch chỉ số hoặc nguồn)");
            }
        } else {
            System.out.println("   => FAIL (Không tìm thấy món ăn)");
        }

        // Test Case 2: International fallback food (Apple)
        System.out.println("\n[Test Case 2] Tra cứu món ăn quốc tế dự phòng (Apple)...");
        NutritionService.FoodNutrition apple = NutritionService.getNutritionInfo("Apple");
        if (apple != null) {
            System.out.println("-> KẾT QUẢ THÀNH CÔNG:");
            System.out.println("   Tên món: " + apple.name);
            System.out.println("   Calo: " + apple.calories + " kcal");
            System.out.println("   Protein: " + apple.protein + " g");
            System.out.println("   Carb: " + apple.carbs + " g");
            System.out.println("   Fat: " + apple.fat + " g");
            System.out.println("   Khẩu phần: " + apple.servingSize);
            System.out.println("   Nguồn dữ liệu: " + apple.source);
            
            // Assert values
            if (apple.calories == 52 && ("MOCK_FALLBACK".equals(apple.source) || "FATSECRET_API".equals(apple.source))) {
                System.out.println("   => PASS");
            } else {
                System.out.println("   => FAIL (Sai lệch chỉ số hoặc nguồn: " + apple.source + ")");
            }
        } else {
            System.out.println("   => FAIL (Không tìm thấy món ăn)");
        }

        // Test Case 3: Non-existent food
        System.out.println("\n[Test Case 3] Tra cứu món ăn không tồn tại...");
        NutritionService.FoodNutrition unknown = NutritionService.getNutritionInfo("randomxyz");
        if (unknown == null) {
            System.out.println("   => PASS (Trả về null chính xác)");
        } else {
            System.out.println("   => FAIL (Tìm thấy kết quả không mong đợi: " + unknown.name + ")");
        }

        // Test Case 4: Real FatSecret API food
        System.out.println("\n[Test Case 4] Tra cứu món ăn thực tế từ FatSecret API (Milk)...");
        NutritionService.FoodNutrition milk = NutritionService.getNutritionInfo("milk");
        if (milk != null) {
            System.out.println("-> KẾT QUẢ THÀNH CÔNG:");
            System.out.println("   Tên món: " + milk.name);
            System.out.println("   Calo: " + milk.calories + " kcal");
            System.out.println("   Protein: " + milk.protein + " g");
            System.out.println("   Carb: " + milk.carbs + " g");
            System.out.println("   Fat: " + milk.fat + " g");
            System.out.println("   Khẩu phần: " + milk.servingSize);
            System.out.println("   Nguồn dữ liệu: " + milk.source);
            System.out.println("   Mô tả: " + milk.description);
            if ("FATSECRET_API".equals(milk.source)) {
                System.out.println("   => PASS (Đã lấy thành công từ FatSecret API)");
            } else {
                System.out.println("   => WARNING (Lấy được dữ liệu nhưng không phải từ FatSecret API: " + milk.source + ")");
            }
        } else {
            System.out.println("   => WARNING (Không lấy được dữ liệu từ FatSecret API - Điều này xảy ra khi IP hiện tại của bạn chưa được thêm vào Whitelist trên trang quản trị FatSecret Developer)");
        }

        System.out.println("\n========== KẾT THÚC KIỂM THỬ ==========");
    }
}
