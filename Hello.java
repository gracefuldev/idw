// OMG there is no package declaration 
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class Hello {
	public static void main(String[] args) throws Exception {
		System.out.println("Hello");

		var content = Files.readString(Paths.get("/workspaces/idw/README.md"));
		System.out.println("README has " + content.split("\n").length + " lines");
		(new Scanner(System.in)).nextLine();
	}
}

