import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import Article from "./Article";
import User from "./User";

@Entity()
class Comment {
  @PrimaryGeneratedColumn()
  id: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column()
  body: string;

  @ManyToOne(() => Article, (article) => article.comments, { cascade: true })
  article: Article;

  @ManyToOne(() => User, (user) => user.comments)
  author: User;
}

export default Comment;
